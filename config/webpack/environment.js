const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const vue =  require('./loaders/vue')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const path = require('path')


environment.loaders.append('vue', vue)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.append('erb', erb)

environment.config.merge({
  resolve: {
    alias: {
      '@components': path.resolve(__dirname, '..', '..', 'app/javascript/components'),
      '@mixins': path.resolve(__dirname, '..', '..', 'app/javascript/mixins'),
      '@modules': path.resolve(__dirname, '..', '..', 'app/javascript/modules')
    }
  }
})
module.exports = environment
