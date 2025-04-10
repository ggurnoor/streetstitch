ActiveAdmin.register Page do
  permit_params :title, :slug, :content

  form do |f|
    f.inputs do
      f.input :title
      f.input :slug, hint: "Use 'about' or 'contact'"
      f.input :content, as: :text
    end
    f.actions
  end

  index do
    selectable_column
    column :title
    column :slug
    actions
  end

  show do
    attributes_table do
      row :title
      row :slug
      row :content do |p|
        simple_format p.content
      end
    end
  end
end
