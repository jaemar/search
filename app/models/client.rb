# frozen_string_literal: true

class Client
  include ActiveModel::Model

  attr_reader :attributes

  def initialize(attrs = {})
    @attributes = attrs
  end

  def id
    attributes['id']
  end

  def as_indexed_json(_options = {})
    attributes
  end

  def method_missing(method_name, *args, &block)
    if attributes.key?(method_name.to_s)
      attributes[method_name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    attributes.key?(method_name.to_s) || super
  end
end
