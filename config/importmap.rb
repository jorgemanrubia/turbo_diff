pin "application-turbo-diff", to: "turbo_diff/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from TurboDiff::Engine.root.join("app/javascript/turbo_diff/controllers"), under: "controllers", to: "turbo_diff/controllers"
pin_all_from TurboDiff::Engine.root.join("app/javascript/turbo_diff/helpers"), under: "helpers", to: "turbo_diff/helpers"
