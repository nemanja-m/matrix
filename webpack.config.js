'use strict';

var path = require('path');
var webpack = require('webpack');

// Helpers for geting path names
function join(destination) {
  return path.resolve(__dirname, destination);
}

function web(destination) {
  return join('web/static/' + destination)
}

var config = module.exports = {

  entry: web('js/app.js'),

  output: {
    path: join('priv/static/js'),
    filename: 'app.js'
  },

  resolve: {
    extensions: ['*', '.js', '.jsx']
  },

  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: [
            'react',
            'es2015',
            'stage-2'
          ],
        },
      }
    ],
  },
};
