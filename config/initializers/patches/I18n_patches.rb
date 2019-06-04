# monkey-patch I18n cascade to not return a hash while cascading keys
module I18n
  module Backend
    module Cascade
      def lookup(locale, key, scope = [], options = EMPTY_HASH)
        return super unless cascade = options[:cascade]

        cascade   = { :step => 1 } unless cascade.is_a?(Hash)
        step      = cascade[:step]   || 1
        offset    = cascade[:offset] || 1
        separator = options[:separator] || I18n.default_separator
        skip_root = cascade.has_key?(:skip_root) ? cascade[:skip_root] : true

        scope = I18n.normalize_keys(nil, key, scope, separator)
        key   = (scope.slice!(-offset, offset) || []).join(separator)

        begin
          result = super
          return result unless result.nil? || (result.is_a?(Hash) && cascade[:allow_hash] == false)
          scope = scope.dup
        end while (!scope.empty? || !skip_root) && scope.slice!(-step, step)
      end
    end
  end
end

# monkey-patch to let I18n.translate (and its alias 't') cascade for keys by default
I18n::Backend::Simple.send(:include, I18n::Backend::Cascade)

ActionView::Base.class_eval do
  def translate(key, options = {})
  	adl_opts = options[:cascade] == false ? {} : {cascade: { skip_root: false, allow_hash: options.has_key?(:count) }}
    super(key, options.reverse_merge(adl_opts))
  end
  alias t translate
end
