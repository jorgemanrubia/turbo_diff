import { Changes } from "turbo_diff/changes"

const initialEtag = document.querySelector("meta[name='turbo-etag']")?.content

addEventListener("turbo:before-fetch-request", function (event) {
  if(!event.target.matches("[data-turbo-diff]"))
    return

  Turbo.navigator.currentEtag = Turbo.navigator.currentEtag || initialEtag

  if(!Turbo.navigator.currentEtag)
    return

  const headers = event.detail.fetchOptions.headers;
  headers["Accept"] = ["text/vnd.turbo-diff.json", headers["Accept"]].join(", ")
  if(Turbo.navigator.currentEtag)
    headers["Turbo-Etag"] = Turbo.navigator.currentEtag
})

addEventListener("turbo:before-fetch-response", async function (event) {
  const response = event.detail.fetchResponse.response;

  if (!response.headers.get("Content-Type").includes("text/vnd.turbo-diff.json"))
    return;

  const etag = response.headers.get("Etag")
  const changes = await response.json()

  document.dispatchEvent(new CustomEvent("turbo:before-diff-render", { detail: { changes: changes } }))


  document.querySelector(".turbo-progress-bar")?.setAttribute("data-turbo-diff-ignore", "")
  new Changes(document.documentElement, changes).apply()

  event.preventDefault()
  Turbo.navigator.currentEtag = etag
})
