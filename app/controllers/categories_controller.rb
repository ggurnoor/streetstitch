class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.all
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Category created successfully."
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category updated."
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Category deleted."
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
  def products
    @category = Category.find(params[:id])
    @products = @category.products
  end

end
