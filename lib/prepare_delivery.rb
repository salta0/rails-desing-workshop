class PrepareDelivery
  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze
  PROCESS_STATUS = :process
  ERROR_STATUS = :error
  OK_STATUS = :ok

  class ExpiredDateError < StandardError
    def message
      'Дата доставки уже прошла'
    end
  end

  class BlankAddressError < StandardError
    def message
      'Нет адреса'
    end
  end

  class TruckNotFoundError < StandardError
    def message
      'Нет машины'
    end
  end

  def initialize(order:, user:, address:, date:)
    @order = order
    @user = user
    @address = address
    @date = date
    @result = { truck: nil, weight: nil, order_number: order.id, address:, status: PROCESS_STATUS, error: nil }
  end

  def perform
    validate_date
    validate_address

    calculate_weight
    select_truck
    complete_prepare

    result
  rescue ExpiredDateError, BlankAddressError, TruckNotFoundError => e
    result[:status] = ERROR_STATUS
    result[:error] = e.message
    result
  end

  private

  attr_reader :order, :user, :address, :date, :result

  def validate_date
    raise ExpiredDateError if date < Time.current
  end

  def validate_address
    %i[city street house].each do |addr_part|
      raise BlankAddressError if address.send(addr_part).empty?
    end
  end

  def calculate_weight
    result[:weight] = order.products.sum(&:weight)
  end

  def sorted_trucks
    @sorted_trucks ||= TRUCKS.sort_by { |_, max_weight| max_weight }
  end

  def select_truck
    sorted_trucks.each do |truck, max_weight|
      if max_weight > result[:weight]
        result[:truck] = truck
        break
      end
    end

    raise TruckNotFoundError if result[:truck].nil?
  end

  def complete_prepare
    result[:status] = OK_STATUS
  end
end
