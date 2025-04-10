ActiveAdmin.register Product do
  permit_params :name, :description, :price, :original_price, :stock, :brand_id, :image, category_ids: []

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :original_price
      f.input :stock
      f.input :brand
      f.input :categories, as: :check_boxes
      f.input :image, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :original_price
      row :stock
      row :brand
      row :categories do |p|
        p.categories.map(&:name).join(", ")
      end
      row :image do |p|
        if p.image.attached?
          image_tag url_for(p.image), width: "150px"
        end
      end
    end
  end
end
