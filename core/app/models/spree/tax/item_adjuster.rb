# @api private
# @note This is a helper class for Tax::OrderAdjuster.  It is marked as api
#   private because taxes should always be calculated on the entire order, so
#   external code should call Tax::OrderAdjuster instead of Tax::ItemAdjuster.
module Spree
  module Tax
    # Adjust a single taxable item (line item or shipment)
    class ItemAdjuster
      attr_reader :item, :order

      include TaxHelpers

      # @param [Spree::LineItem,Spree::Shipment] item to adjust
      # @param [Hash] options like already known tax rates for the order's zone
      def initialize(item, options = {})
        @item = item
        @order = @item.order
        # set instance variable so `TaxRate.match` is only called when necessary
        @rates_for_order_zone = options[:rates_for_order_zone]
        @rates_for_default_zone = options[:rates_for_default_zone]
        @order_tax_zone = options[:order_tax_zone]
      end

      # Deletes all existing tax adjustments and creates new adjustments for all
      # (geographically and category-wise) applicable tax rates.
      #
      # @return [Array<Spree::Adjustment>] newly created adjustments
      def adjust!
        return unless order_tax_zone(order)

        item.adjustments.destroy(item.adjustments.select(&:tax?))

        rates_for_item(item).map { |rate| rate.adjust(order_tax_zone(order), item) }
      end
    end
  end
end
