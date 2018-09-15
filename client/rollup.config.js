import { uglify } from "rollup-plugin-uglify"
import commonjs from "rollup-plugin-commonjs"
import elm from "rollup-plugin-elm"
import html from "rollup-plugin-fill-html"
import path from "path"
import postcss from "rollup-plugin-postcss"
import replace from "rollup-plugin-replace"
import resolve from "rollup-plugin-node-resolve"
import serve from "rollup-plugin-serve"
import typescript from "rollup-plugin-typescript2"
import clear from 'rollup-plugin-clear'
import livereload from 'rollup-plugin-livereload'

const PROD = "PROD"
const DEV = "DEV"

var serveConfig = {
	contentBase: "dist-dev",
	historyApiFallback: true,
	port: 8080,
}

let TARGET = process.env.ENV == "prod"
	? PROD
	: DEV

let outputDir = TARGET == PROD
	? "dist-prod"
	: "dist-dev"

export default {
	input: "./src/app.ts",
	output: {
		name: "App",
		file: path.resolve(__dirname, outputDir, "app-[hash].js"),
		format: "iife"
	},
	plugins: [

		clear({
			targets: [outputDir],
		}),

		resolve(),

		commonjs(),

		postcss({
			extract: true
		}),

		typescript({
			typescript: require("typescript")
		}),

		elm(),

		replace({
			exclude: 'node_modules/**',
			API_HOST: JSON.stringify(process.env.API_HOST),
		}),

		html({
			template: "src/app.html",
			filename: "index.html",
		}),

		// (TARGET === PROD && uglify()),

		// serve(serveConfig),

		// livereload({
		// 	watch: outputDir,
		// })
	]
};
