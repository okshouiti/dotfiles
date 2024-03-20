// ==UserScript==
// @name         Reddit Image Duplication Remover
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  同じ画像のPostをひとつにまとめる
// @author       okshouiti
// @match        https://www.reddit.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=reddit.com
// @grant        none
// ==/UserScript==

// 画像リンクの集合
const imgSet = new Set();

// 処理した最後のpostの添字
let lastIdx = -1;

function hidePostIfDuplication() {
  const posts = document.querySelectorAll(".Post");
  const startIdx = lastIdx + 1;
  const lastPostIdx = posts.length - 1;

  lastIdx = lastPostIdx;

  for (let i = startIdx; i < lastPostIdx + 1; i++) {
    const post = posts[i];
    const imgLinks = post.querySelectorAll('a[data-testid="outbound-link"]');
    if (imgLinks == null || imgLinks.length == 0) {
      continue;
    }

    // 新しい画像を含むpostなら
    let isHideTarget = true;

    // 画像リンク有り、かつ既出でなければ登録して非表示対象から外す
    for (const link of imgLinks) {
      const ref = link.href;
      if (ref == null || ref.length == 0) continue;
      if (imgSet.has(ref)) continue;

      // 新しいリンクがある場合
      imgSet.add(ref); // 登録
      isHideTarget = false;
    }

    // 新しい画像がなければ非表示にする
    if (isHideTarget) {
      post.style.display = "none";
    }
  }
}

(function () {
  "use strict";

  // 初回読み込み分の処理
  hidePostIfDuplication();

  // 変更検知時の処理
  const observer = new MutationObserver(hidePostIfDuplication);

  // 監視対象を指定して監視開始
  const postsContainer = document.querySelector(
    ".ListingLayout-outerContainer"
  );
  observer.observe(postsContainer, {
    childList: true,
    subtree: true,
  });

  // タイトル
  //demo[94].querySelectorAll('a[data-click-id="body"]')
})();
