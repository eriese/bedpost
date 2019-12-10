const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// fix webpacker's outdated setup for anything using css-loader
module.exports = function(environment) {

	const cssExtract = environment.plugins.find((p) => p.key == 'MiniCssExtract');
	const extractIndex = environment.plugins.indexOf(cssExtract);
	const MiniCssExtract = new MiniCssExtractPlugin( {
		chunkFilename: 'css/[name]-[contenthash].chunk.css',
		filename: 'css/[name]-[contenthash].css',
	});
	environment.plugins[extractIndex] = {key: 'MiniCssExtract', value: MiniCssExtract};

	environment.loaders.forEach((loader) => {
		let thisLoader = loader.value;
		let cssLoader = thisLoader.use.find(function(el){
			return el.loader == 'css-loader';
		});
		if (!cssLoader) {
			return;
		}

		thisLoader.use.unshift({loader: 'vue-style-loader', options: {}});
		if(cssLoader.options.modules) {
			cssLoader.options.modules = {localIdentName: cssLoader.options.localIdentName};
		}

		delete cssLoader.options.localIdentName;
	});
};
