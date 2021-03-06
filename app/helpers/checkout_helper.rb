#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

module CheckoutHelper
  def unified_transport_label_for group, price
    I18n.t('cart.texts.unified_transport', provider: group.seller.unified_transport_provider, price: money(price))
  end

  def checkout_options_for_payment selectables
    selectables.map { |payment| [I18n.t("enumerize.business_transaction.selected_payment.#{payment}"), payment] }
  end

  def checkout_options_for_single_transport line_item, preview
    transports = []
    # pickup should be last in list, that's why we assign a large value for compariso reasons
    preview[line_item].sort_by { |k, v| k == 'pickup' ? 1000000 : v.cents }.each do |transport, cost|
      provider = line_item.article.transport_provider transport
      transports.push ["#{ provider } (+#{ money(cost) })", transport]
    end
    transports
  end

  def unified_transport_first a, b
    a_value = a.article.unified_transport
    b_value = b.article.unified_transport
    if a_value == b_value
      0
    elsif a_value
      -1
    else
      1
    end
  end

  def terms_and_cancellation_label_for user
    terms_link = checkbox_link_helper I18n.t('cart.texts.terms'), profile_user_path(user, print: 'terms', format: :pdf)
    cancellation_link = checkbox_link_helper I18n.t('cart.texts.cancellation'), profile_user_path(user, print: 'cancellation', format: :pdf)
    I18n.t('cart.texts.terms_and_cancellation_label', terms: terms_link, cancellation: cancellation_link).html_safe
  end

  def line_item_group_title group
    t('cart.texts.line_item_group_by', seller: link_to(group.seller_nickname, user_path(group.seller))).html_safe
  end

  def visual_checkout_steps step, cart
    render 'carts/checkout/visual_steps', step: step, cart: cart
  end

  def visual_checkout_step step, active, checked, link = nil
    step_title = I18n.t("cart.steps.#{step}")
    content_tag :span, class: "visual_checkout_step #{active ? 'active' : ''}" do
      concat(content_tag(:i, '', class: (checked ? 'fa fa-check-square-o' : 'fa fa-square-o')))
      concat(' ')
      concat(link ? link_to(step_title, link) : step_title)
    end
  end

  # Show valid range of shipping times for courier_service
  #
  def courier_time_for line_item
    line_item.article_seller
  end
end
