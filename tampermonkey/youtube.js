// ==UserScript==
// @name         Unsplash Downloader
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description
// @author       okshouiti
// @match        https://www.youtube.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=unsplash.com
// @grant        none
// ==/UserScript==

/**
 * 処理を一定時間停止
 * @param {string} millis 停止時間ms
 * @returns
 */
async function sleep(millis) {
  return new Promise((resolve) => setTimeout(resolve, millis));
}

const selectElmAll = (selector) =>
  Array.from(document.querySelectorAll(selector));

const deleteGameMetadata = () =>
  selectElmAll(
    "ytd-watch-metadata > ytd-metadata-row-container-renderer"
  ).forEach((elm) => elm.remove());

const deletePostComment = () =>
  selectElmAll(".ytd-comments #simple-box").forEach((elm) => elm.remove());

const deleteRelatedVids = () =>
  selectElmAll("#related #contents > *")
    .slice(6)
    .forEach((elm) => elm.remove());

(async function () {
  "use strict";

  await sleep(3000);

  deleteGameMetadata();
  deletePostComment();
  deleteRelatedVids();
})();
