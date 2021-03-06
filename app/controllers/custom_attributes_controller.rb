class CustomAttributesController < ApplicationController
  before_filter :check_permission

  def index
    @attributables = []
    @attributables << [ "User", _("User") ]
    @attributables << [ "Customer", _("Client") ]

  end

  def edit
    @attributes = CustomAttribute.attributes_for(current_user.company, params[:type])
  end

  def update
    update_existing_attributes(params) if params[:custom_attributes]
    create_new_attributes(params) if params[:new_custom_attributes]

    flash[:notice] = _("Custom attributes updated")
    redirect_to(:action => "edit", :type => params[:type])
  end

  private

  def update_existing_attributes(params)
    attributes = CustomAttribute.attributes_for(current_user.company, params[:type])

    updated = []
    params[:custom_attributes].each do |id, values|
      attr = attributes.detect { |ca| ca.id == id.to_i }
      updated << attr

      attr.update_attributes(values)
    end
    missing = attributes - updated
    missing.each { |ca| ca.destroy }
  end

  def create_new_attributes(params)
    params[:new_custom_attributes].each do |values|
      values[:attributable_type] = params[:type]
      current_user.company.custom_attributes.create(values)
    end
  end

  def check_permission
    if !current_user.admin?
      can_view = false
      redirect_to(:controller => "activities", :action => "list")
    end

    return can_view
  end
end
