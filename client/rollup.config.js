import typescript from "rollup-plugin-typescript2";
import elm from "rollup-plugin-elm"
import resolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
// import path from "path"

export default {
	input: "./src/public.ts",
	output: {
		file: "./dist-dev/public.js",
		format: "iife"
	},
	plugins: [
		resolve(),
		commonjs(),
		typescript({
			typescript: require("typescript")
		}),
		elm({
			exclude: "elm_stuff/**",
			// pathToElm: path.resolve("/usr/local/bin/elm")
		})
	]
};
