# frozen_string_literal: true

class ServiceErrors
  class CloudPaymentError < StandardError
    attr_reader :user, :product, :status

    def initialize(user:, product:, status:)
      @user = user
      @product = product
      @status = status
      super
    end

    def message
      "Cloud payment failed with #{staus} for " \
      "product: #{product.id}, user: #{user.id}"
    end
  end

  class SdekError < StandardError
    attr_reader :user, :product, :status

    def initialize(user:, product:, status:)
      @user = user
      @product = product
      @status = status
      super
    end

    def message
      "Setup sdek failed with #{staus} for " \
      "product: #{product.id}, user: #{user.id}"
    end
  end
end
