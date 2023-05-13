class SandboxesController < ApplicationController
  def show
    @content = session[:sandbox_content]
    fresh_when etag: @content
  end

  def create
    session[:sandbox_content] = params[:sandbox_content]
    redirect_to sandbox_path
  end
end
