const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')
const VueLoaderPlugin = require('vue-loader/lib/plugin')


environment.loaders.append('vue', vue)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin());
module.exports = environment
