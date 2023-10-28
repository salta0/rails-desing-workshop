# frozen_string_literal: true

class MakePaymentService
  SETUP_DELIVERY_SUCCESS = 'succeed'

  def initialize(user:, product:, delivery_info:)
    @user = user
    @product = product
    @delivery_info = delivery_info
  end

  def call
    setup_delivery(
      address: delivery_info[:address],
      person: delivery_info[:person],
      weight: product.weight
    )
    delivery_doc = create_delivery_doc
    sent_delivery_doc_notification(delivery_doc)

    { status: 'success', message: 'Delivery setup complete' }
  rescue ServiceErrors::SdekError
    # log_error

    { status: 'fail', message: 'Delivery setup failed' }
  end

  private

  attr_reader :product, :user, delivery_info

  def setup_delivery(address:, person:, weight:)
    res = Sdek.setup_delivery(address:, person:, weight:)
    return if res[:status] == SETUP_DELIVERY_SUCCESS

    raise ServiceErrors::SdekError.new(product:, user:, status: res[:status])
  # Sdek::Error - ошибка, которая
  # может возникнуть, если сервис не доступен
  rescue Sdek::Error => e
    raise ServiceErrors::SdekError.new(product:, user:, status: e.message)
  end

  def create_delivery_doc
    DeliveryDoc.create(user:, product:, delivery_info:)
  end

  def sent_delivery_doc_notification(delivery_doc)
    OrderMailer.delivery_notification_email(delivery_doc).deliver_later
  end
end
