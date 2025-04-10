class PagesController < ApplicationController
  before_action :set_page, only: [:about, :contact]
  before_action :require_admin, only: [:edit, :update]

  def about; end
  def contact; end

  def edit
    @page = Page.find_by(slug: params[:slug])
  end

  def update
    @page = Page.find_by(slug: params[:slug])
    if @page.update(page_params)
      redirect_to "/#{@page.slug}", notice: "#{@page.title} updated."
    else
      render :edit
    end
  end

  private

  def set_page
    @page = Page.find_by(slug: action_name)
  end

  def page_params
    params.require(:page).permit(:content)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
