const initialEtag = document.querySelector("meta[name='turbo-etag']").content

addEventListener("turbo:before-fetch-request", function (event) {
  Turbo.navigator.currentEtag = Turbo.navigator.currentEtag || initialEtag
  console.debug("OLE", Turbo.navigator.currentEtag);

  const headers = event.detail.fetchOptions.headers;
  headers["Accept"] = ["text/vnd.turbo-diff.json", headers["Accept"]].join(", ")
  if(Turbo.navigator.currentEtag)
    headers["Turbo-Etag"] = Turbo.navigator.currentEtag
})

addEventListener("turbo:before-fetch-response", function (event) {
  const etag = event.detail.fetchResponse.response.headers.get("Etag")
  Turbo.navigator.currentEtag = etag
})

console.debug("HOLA!!!");
