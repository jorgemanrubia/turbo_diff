import { DiffChanges } from "diff_changes"

const initialEtag = document.querySelector("meta[name='turbo-etag']").content

addEventListener("turbo:before-fetch-request", function (event) {
  Turbo.navigator.currentEtag = Turbo.navigator.currentEtag || initialEtag

  const headers = event.detail.fetchOptions.headers;
  headers["Accept"] = ["text/vnd.turbo-diff.json", headers["Accept"]].join(", ")
  if(Turbo.navigator.currentEtag)
    headers["Turbo-Etag"] = Turbo.navigator.currentEtag
})

addEventListener("turbo:before-fetch-response", async function (event) {
  const response = event.detail.fetchResponse.response;
  const etag = response.headers.get("Etag")
  const changes = await response.json()

  new DiffChanges(document.documentElement, changes).apply()

  event.preventDefault()
  Turbo.navigator.currentEtag = etag
})
