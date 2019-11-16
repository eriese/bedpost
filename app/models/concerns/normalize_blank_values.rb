# make blank values nil before saving in the database
# modified from https://solidfoundationwebdev.com/blog/posts/make-values-nil-if-blank-data-normalization-in-rails
module NormalizeBlankValues
  extend ActiveSupport::Concern

  included do
    before_save :normalize_blank_values
  end

  def normalize_blank_values
    attributes.each do |column, value|
    	next if value.present?
      self[column] = fields[column].type == Mongoid::Boolean ? false : nil
    end
  end
end
