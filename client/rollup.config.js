import typescript from "rollup-plugin-typescript2";
import elm from "rollup-plugin-elm"
import resolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs"
import serve from 'rollup-plugin-serve'
import htmlTemplate from 'rollup-plugin-generate-html-template'

var serveConfig = {
	contentBase: "dist-dev",
}

export default {
	input: "./src/app.ts",
	output: {
		file: "./dist-dev/app.js",
		format: "iife"
	},
	plugins: [
		resolve(),
		commonjs(),
		typescript({
			typescript: require("typescript")
		}),
		elm(),
		htmlTemplate({
			template: 'src/app.html',
			target: 'index.html',
		}),
		serve(serveConfig)
	]
};
