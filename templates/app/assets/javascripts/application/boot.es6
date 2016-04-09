import $ from "jquery";

function runner() {
  var path = $("body").data("route");

  // Load script for this page.
  // We should use System.import, but it's not worth the trouble, so
  // let's use almond's require instead.
  try {
    require([path], onload, null, true);
  } catch (error) {
    handleError(error);
  }
}

function onload(Page) {
  // Instantiate the page, passing <body> as the root element.
  var page = new Page($(document.body));

  // Set up page and run scripts for it.
  if (page.setup) {
    page.setup();
  }

  if (page.run) {
    page.run();
  } else {
    console.warn("module found, but it doesn't implement run().", Page);
  }
}

// Handles exception.
function handleError(error) {
  if (error.message.match(/undefined missing/)) {
    console.warn("missing module:", error.message.split(" ").pop());
  } else {
    throw error;
  }
}

$(window)
  .ready(runner)
  .on("turbolinks:load", runner);
