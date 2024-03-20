// ==UserScript==
// @name         Unsplash Downloader
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description
// @author       okshouiti
// @match        https://unsplash.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=unsplash.com
// @grant        none
// ==/UserScript==

function escaped_filename(filename) {
  let result = "";
  for (const c of filename) {
    switch (c) {
      case "<":
        result += "＜";
        break;
      case ">":
        result += "＞";
        break;
      case ":":
        result += "：";
        break;
      case '"':
        result += "”";
        break;
      case "/":
        result += "／";
        break;
      case "\\":
        result += "＼";
        break;
      case "|":
        result += "｜";
        break;
      case "?":
        result += "？";
        break;
      case "*":
        result += "＊";
        break;
      case "\r":
        break;
      case "\n":
        result += " ";
        break;
      default:
        result += c;
        break;
    }
  }
  return result;
}

(function () {
  "use strict";

  const infoObj = JSON.parse(
    document.querySelector('div[data-test="photos-route"] script').textContent
  );
  const imgName = escaped_filename(
    infoObj.author.name + "　" + (infoObj.caption ?? "unknown")
  );

  // ダウンロードボタンの作成
  const newBtnParent = document.querySelector(
    "#app header:first-of-type + div header:first-of-type > div:last-of-type"
  );

  // URL
  //const imgUrl = newBtnParent.lastChild.firstChild.firstChild.href;
  const url = new URL(newBtnParent.lastChild.firstChild.firstChild.href);
  const imgUrl = new URL(url.href);

  const myElmWrapper = document.createElement("a");
  myElmWrapper.setAttribute("href", imgUrl.pathname + imgUrl.search);
  myElmWrapper.setAttribute("download", "filename.jpg");
  const myElm = document.createElement("button");
  myElm.textContent = "Download";
  myElm.setAttribute("id", "dl-btn");
  myElm.addEventListener("click", (arg) => {
    navigator.clipboard.writeText(imgName);
  });
  myElmWrapper.prepend(myElm);
  newBtnParent.prepend(myElmWrapper);
})();
