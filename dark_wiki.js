// from incredible-gmod.ru with <3
// https://github.com/Be1zebub/Small-GLua-Things/blob/master/dark_wiki.js
// https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo required

// ==UserScript==
// @name         Gmod Wiki Dark Theme
// @namespace    https://wiki.facepunch.com/gmod/
// @version      0.3
// @description  Incredible dark theme for wiki.facepunch.com/gmod
// @author       Phoenixf129 & Beelzebub
// @match        https://wiki.facepunch.com/*
// @exclude      *~edit
// @icon         https://incredible-gmod.ru/assets/icons/inc32icon.png
// @grant        none
// ==/UserScript==

(function() {
    "use strict";

    var Style = `
		:root {
			color-scheme: dark;
		}
		::-webkit-scrollbar {
			width: 0.5em;
		}
		::-webkit-scrollbar-thumb {
			background: rgb(92, 92, 92)
		}
		::-webkit-scrollbar-thumb:hover{
			background: rgb(31, 31, 31);
		}
		.body > .content, #pagelinks a.active {
			background: url(https://i.imgur.com/iKHU5u8.png);
		}
		.body, body > div.body > div.footer, body > div.body > div.content {
			background: url(https://i.imgur.com/iKHU5u8.png);
			background-color: rgba(0, 0, 0, 0.2) !important;
            backdrop-filter: blur(2px);
		}
		.body > .footer > div > div ul li a {
			color: #fff;
		}
		.markdown > .function .function_line {
			background-color: rgba(0, 0, 0, 0.25) !important;
			backdrop-filter: blur(4px);
		}
		.body-tabs ul li a.active {
			background-color: #333;
			color: #fff;
		}
		.markdown {
			color: #999;
		}
		.markdown .code {
			background-color: rgba(0, 0, 0, 0.25) !important;
			backdrop-filter: blur(4px);
		}
        .markdown code {
			background-color: rgba(0, 0, 0, 0.5) !important;
			backdrop-filter: blur(4px);
        }
		.markdown span.key {
			background-color: #000;
		}
		.markdown h2 {
			color: #0082ff;
		}
		.markdown h3 {
			color: #0082ff;
		}
		.body-tabs ul li a {
			color: #fff;
		}
		.markdown table td {
			border: 1px solid #111;
			background-color: #222;
		}
		.markdown table th {
			border: 1px solid #111;
			background-color: #333;
		}
		.member_line {
			color: #999;
		}
		.member_line a.subject {
			color: #0082ff !important;
		}

		#ident > h1 > a::after {
			content: "deprecated";
		    background-color: #b14a00;
		    color: #efefef;
		    font-size: 7px;
		    text-transform: uppercase;
		    padding: 2px;
		    margin-left: 5px;
		    display: inline-block;
		    position: relative;
		    top: -4px;
		}
    `;

    function addGlobalStyle(css) {
        var head, style;
        head = document.getElementsByTagName("head")[0];
        if (!head) { return; }
        style = document.createElement("style");
        style.type = "text/css";
        style.innerHTML = css;
        head.appendChild(style);
    }

    function setElemStyle(selector, sname, svalue) {
        var elem = document.querySelector(selector);
        if (elem !== null) {
            elem.style[sname] = svalue;
        }
    }

    addGlobalStyle(Style);
})();
