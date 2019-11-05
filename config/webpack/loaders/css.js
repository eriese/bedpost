// fix webpacker's outdated setup for anything using css-loader
module.exports = function(environment) {
	for (var i = 0; i < environment.loaders.length; i++) {
	  let thisLoader = environment.loaders[i].value
	  let cssLoader = thisLoader.use.find(function(el){
	    return el.loader == 'css-loader'
	  })
	  if (!cssLoader) {
	    continue;
	  }

	  thisLoader.use.unshift({loader: 'vue-style-loader', options: {}})
	  if(cssLoader.options.modules) {
		  cssLoader.options.modules = {localIdentName: cssLoader.options.localIdentName}
		}

	  delete cssLoader.options.localIdentName
	}
}
