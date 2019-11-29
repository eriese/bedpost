const { environment } = require('@rails/webpacker');
const { VueLoaderPlugin } = require('vue-loader');
const vue = require('./loaders/vue');
const cssFix = require('./loaders/css');
// const erb =  require('./loaders/erb')
const path = require('path');

cssFix(environment);
environment.loaders.append('vue', vue);
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin());

environment.config.merge({
	resolve: {
		alias: {
			'@components': path.resolve(__dirname, '..', '..', 'app/javascript/components'),
			'@mixins': path.resolve(__dirname, '..', '..', 'app/javascript/mixins'),
			'@modules': path.resolve(__dirname, '..', '..', 'app/javascript/modules'),
			'@plugins': path.resolve(__dirname, '..', '..', 'app/javascript/plugins'),
			'@locales': path.resolve(__dirname, '..', '..', 'app/javascript/locales'),
			'@stylesheets': path.resolve(__dirname, '..', '..', 'app/assets/stylesheets')
		}
	},
	optimization: {
		runtimeChunk: 'single',
		moduleIds: 'hashed',
		splitChunks: {
			chunks: 'async',
			cacheGroups: {
				vendor: {
					test: /[\\/]node_modules[\\/]/,
					chunks: 'async',
					name(module) {
						// get the name. E.g. node_modules/packageName/not/this/part.js
						// or node_modules/packageName
						const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];

						// npm package names are URL-safe, but some servers don't like @ symbols
						return `npm.${packageName.replace('@', '')}`;
					}
				},
				locale: {
					test: /[\\/]locales[\\/]/,
					chunks: 'async',
					name(module) {
						const packageName = module.rawRequest.replace(/^.[\\/]/, '').replace('.json', '');
						return `locales.${packageName}`;
					}
				}
			}
		}
	}
});

module.exports = environment;
