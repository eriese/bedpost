const { environment } = require('@rails/webpacker');
const { VueLoaderPlugin } = require('vue-loader');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

const vue = require('./loaders/vue');
const cssFix = require('./loaders/css');
// const erb =  require('./loaders/erb')
const path = require('path');

cssFix(environment);
environment.loaders.append('vue', vue);
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin({
	chunkFilename: 'js/vue/[name]-[contenthash].chunk.js'
}));
// environment.plugins.append('CleanWebpackPlugin', new CleanWebpackPlugin());

environment.config.merge({
	resolve: {
		alias: {
			'@components': path.resolve(__dirname, '..', '..', 'app/javascript/components'),
			'@mixins': path.resolve(__dirname, '..', '..', 'app/javascript/mixins'),
			'@modules': path.resolve(__dirname, '..', '..', 'app/javascript/modules'),
			'@plugins': path.resolve(__dirname, '..', '..', 'app/javascript/plugins'),
			'@locales': path.resolve(__dirname, '..', '..', 'app/javascript/locales'),
			'@stylesheets': path.resolve(__dirname, '..', '..', 'app/assets/stylesheets'),
		}
	},
	output: {
		chunkFilename: 'js/[name]-[contenthash].chunk.js',
	},
	optimization: {
		runtimeChunk: 'single',
		moduleIds: 'hashed',
		chunkIds: 'named',
		// splitChunks: {
		// 	maxAsyncRequests: Infinity,
		// 	maxInitialRequests: Infinity,
		// 	chunks: 'async',
		// 	name(module, chunks, cacheGroupKey) {
		// 		const moduleFileName = module.identifier().split('/').reduceRight(item => item).replace(/\.js(on)?/, '');
		// 		if (moduleFileName.indexOf('css') >= 0) {
		// 			return `${cacheGroupKey}-css/${moduleFileName.split('?')[0]}`;
		// 		}
		// 		return `${cacheGroupKey}/${moduleFileName}`;
		// 	},
		// 	cacheGroups: {
		// 		vendors: {
		// 			reuseExistingChunk: true,
		// 		},
		// 		locale: {
		// 			test: /locales/,
		// 		}
		// 	}
		// }
	}
});

module.exports = environment;
