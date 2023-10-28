# frozen_string_literal: true

class MakePaymentService
  def initialize(product:, user:, delivery_info:)
    @product = product
    @user = user
    @delivery_info = delivery_info
  end

  def call
    payment_result = ProcessCloudPaymentService.new(user:, product:).call
    return payment_result unless payment_result[:status] == 'success'

    delivery_result = SetupSdekDeliveryService.new(user:, product:, delivery_info:).call
    return delivery_result unless delivery_result[:status] == 'success'

    { status: 'success', message: 'Payment and delivery complete' }
  end

  private

  attr_reader :product, :user, :delivery_info
end
