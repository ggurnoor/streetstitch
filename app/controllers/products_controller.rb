class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
    @products = Product.all

    # Full-text search (on name or description)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @products = @products.where("products.name ILIKE ? OR products.description ILIKE ?", search_term, search_term)
    end

    # Filter by category
    if params[:category_id].present?
      @products = @products.joins(:categories).where(categories: { id: params[:category_id] })
    end

    # Filter by time-based criteria
    case params[:filter]
    when "new"
      @products = @products.where("products.created_at >= ?", 3.days.ago)
    when "sale"
      @products = @products.where("products.original_price IS NOT NULL AND products.price < products.original_price")
    end

    @products = @products.page(params[:page]).per(12)

  end

  def show; end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy!
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :original_price, :stock, :brand_id, :image, category_ids: []
    )
  end

end
