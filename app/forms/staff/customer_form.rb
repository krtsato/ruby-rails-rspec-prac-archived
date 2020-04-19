# frozen_string_literal: true

module Staff
  class CustomerForm
    include ActiveModel::Model
    attr_accessor :customer, :inputs_home_address, :inputs_work_address

    delegate :persisted?, :save, to: :customer

    def initialize(customer = nil)
      @customer = customer
      @customer ||= Customer.new(gender: 'male')
      self.inputs_home_address = @customer.home_address.present?
      self.inputs_work_address = @customer.work_address.present?
      @customer.build_home_address unless @customer.home_address
      @customer.build_work_address unless @customer.work_address
    end

    def assign_attributes(params = {})
      @params = params
      self.inputs_home_address = params[:inputs_home_address] == '1' # true: 1, false: 0
      self.inputs_work_address = params[:inputs_work_address] == '1' # true: 1, false, 0

      customer.assign_attributes(customer_params)
      home_address_assign_divider(inputs_home_address)
      work_address_assign_divider(inputs_work_address)
    end

    private

    def customer_params
      @params.require(:customer).permit(
        :email, :password, :family_name, :given_name,
        :family_name_kana, :given_name_kana, :birthday, :gender
      )
    end

    def home_address_params
      @params.require(:home_address).permit(:postal_code, :prefecture, :city, :address1, :address2)
    end

    def work_address_params
      @params.require(:work_address).permit(
        :postal_code, :prefecture, :city, :address1, :address2, :company_name, :division_name
      )
    end

    def home_address_assign_divider(is_home_address)
      if is_home_address
        customer.home_address.assign_attributes(home_address_params)
      else
        customer.home_address.mark_for_destruction
      end
    end

    def work_address_assign_divider(is_work_address)
      if is_work_address
        customer.work_address.assign_attributes(work_address_params)
      else
        customer.work_address.mark_for_destruction
      end
    end
  end
end
