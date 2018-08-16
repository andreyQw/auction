# frozen_string_literal: true

module RenderMethods
  extend ActiveSupport::Concern

  private

    def render_resource_or_errors(resource, options = {})
      resource.try(:errors).present? ? render_errors(resource) : render_resource(resource, options)
    end

    def render_errors(resource)
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end

    def render_resource(resource, options = {})
      render json: resource, root: :resource, **options
    end

    def render_resources(resources, options = {})
      page = params[:page] || 1
      per_page = params[:per_page]
      resources = resources.page(page).per(per_page) unless options[:pagination]

      render json: resources, root: :resources, each_serializer: LotSerializer
    end
end
