const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
// const erb =  require('./loaders/erb')
const path = require('path')


environment.loaders.append('vue', vue)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin());

// environment.loaders.append('css', {
// 	test: /\.s?css$/,
// 	use: [
// 	'vue-style-loader',
// 	'style-loader',
// 	'css-loader',
// 	'sass-loader'
// 	]
// })

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
