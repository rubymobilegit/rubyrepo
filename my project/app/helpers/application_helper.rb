module ApplicationHelper


  def numbered_input form, attribute, simple_form_options={}
    @numbered_input_counters ||= {}
    @numbered_input_counters[form.object_id] ||= 0
    @numbered_input_counters[form.object_id] += 1

    title = strip_tags(form.label(attribute))

    result = "<span class='num' title='#{title}'>#{@numbered_input_counters[form.object_id]}.</span>"
    result += no_label_input(form, attribute, simple_form_options)
    result.html_safe
  end

  def fetch_image_of_advertiser(advertiser, style)
    advertiser.image.exists? ? advertiser.image.url(style.to_sym) : (advertiser.is_a?(LinkshareAdvertiser) ? advertiser.logo_url : advertiser.logo.url)
  end

  def no_label_input  form, attribute, simple_form_options={}
    title = strip_tags(form.label(attribute, :label=>simple_form_options[:label]))
    options = {:input_html=>{:title=>title}}
    options[:label] = false unless simple_form_options[:use_label]

    defaults = {:placeholder=>title}

    form.input attribute, defaults.merge(simple_form_options.deep_merge(options))
  end

  def input_row form, attribute, simple_form_options={}
    return form.input(attribute, simple_form_options) + tag(:hr)
  end

  def inputs_grouped form, attribute, label=nil, hint=nil, required=nil, &block
    content_tag(:div, :class=>"input grouped") do
      content_tag(:div, :class=>'col desc') do
        form.label(attribute, :label=>label, :required=>required) +
          form.hint(hint.blank? ? attribute : hint)
      end + content_tag(:div, :class=>'col flds') do
        yield
      end
    end + tag(:hr)
  end

  def sub_input_row form, attribute, simple_form_options={}
    form.input(attribute, {:wrapper=>:sub_input}.merge(simple_form_options))
  end

  def times_of_day_options
    [['Any time', '']] + $times_of_day.map { |t| [t,t] }
  end

  def seconds_to_time number_of_seconds
    return '' if number_of_seconds.blank?
    hours = (number_of_seconds/3600).to_i
    minutes = (number_of_seconds/60 - hours * 60).to_i
    seconds = (number_of_seconds - (minutes * 60 + hours * 3600))
    sprintf("%02d:%02d:%02d", hours, minutes, seconds)
  end

  def seconds_to_days_and_time number_of_seconds, include_seconds=true
    return '' if number_of_seconds.blank?
    days = number_of_seconds/(3600 * 24)
    hours = (number_of_seconds/3600 - days *  24).to_i
    minutes = (number_of_seconds.to_f/60.0 - (hours * 60 + days * 24 * 60).to_f)
    minutes = include_seconds ? minutes.to_i : minutes.round
    seconds = (number_of_seconds - (minutes * 60 + hours * 3600 + days * (3600 * 24)))
    if include_seconds
      sprintf("%01dd %01dh %01dm %01ds", days, hours, minutes, seconds)
    else
      sprintf("%01dd %01dh %01dm", days, hours, minutes)
    end
  end

  def seconds_to_days_and_time_html number_of_seconds
    return '' if number_of_seconds.blank?
    days = number_of_seconds/(3600 * 24)
    hours = (number_of_seconds/3600 - days *  24).to_i
    minutes = (number_of_seconds/60 - (hours * 60 + days * 24 * 60)).to_i
    seconds = (number_of_seconds - (minutes * 60 + hours * 3600 + days * (3600 * 24)))
    sprintf("<span class='days'>%01d</span>d <span class='hours'>%01d</span>h <span class='minutes'>%01d</span>m <span class='seconds'>%01d</span>s",
      days, hours, minutes, seconds).html_safe
  end

  def paginate *params
    params[1] = {} if params[1].nil?
    params[1][:renderer] = PaginationViewRenderer
    will_paginate *params
  end

  def format_currency value
    number_to_currency(number_with_precision(value, :precision => 2))
  end

  def format_percent_strip value
    number_to_percentage(value, {:precision=>1, :strip_insignificant_zeros=>true})
  end

  def format_datetime value
    value && value.strftime('%m/%d/%Y at %R')
  end

  def format_date value
    value && value.strftime('%m/%d/%Y')
  end

  def url_without_http url
    url.gsub(/https?:\/\//, '')
  end

  def url_with_http url
    http = /https?:\/\//
    if(url.match(http))
      url
    else
      "http://#{url}"
    end
  end

  def trackable_offer_link auction_id, offer
    return '' if offer.offer_url.blank?
    offer_url = url_with_http(offer.trackable_offer_url(auction_id))
    link = create_vendor_tracking_event_path('clicked', :v=>offer.vendor_id, :a=>auction_id,
      :redirect_to=>offer_url)
    link_to offer.offer_url, offer_url, :target=>'_blank', :class=>'trackable-link', :"data-link"=>link
  end

  def list_order_url list_name, param_name
    dir = :ASC
    if instance_variable_get("@#{list_name}_order").to_sym == param_name.to_sym
      dir = instance_variable_get("@#{list_name}_dir").to_sym == :ASC ? :DESC : :ASC
    end
    url_for(params.merge({:"#{list_name}_order" => param_name, :"#{list_name}_dir"=>dir, :"#{list_name}_page"=>nil}))
  end

  def list_order_class list_name, param_name
    ''
    if instance_variable_get("@#{list_name}_order").to_sym == param_name.to_sym
      'active' + if instance_variable_get("@#{list_name}_dir").to_sym == :DESC
        ' up'
      else
        ''
      end
    end
  end

  def credit_card_types
    [
      ["Visa", "visa"], ["MasterCard", "master"],
      ["Discover", "discover"], ["American Express", "american_express"]
    ]
  end

  def facebok_include_sdk
    '<div id="fb-root"></div>' +
      '<script>(function(d, s, id) {'+
      'var js, fjs = d.getElementsByTagName(s)[0];'+
      'if (d.getElementById(id)) return;'+
      'js = d.createElement(s); js.id = id;'+
      "js.src = '//connect.facebook.net/en_US/all.js#xfbml=1&appId=#{SOCIAL_CONFIG['fb_app_id']}';"+
      'fjs.parentNode.insertBefore(js, fjs);'+
      "}(document, 'script', 'facebook-jssdk'));</script>".html_safe
  end

  def facebook_like_button page_url
    '<div class="fb-like" data-href="' + page_url + '" data-send="false"' +
      ' data-layout="button_count" data-width="450" data-show-faces="false"></div>'.html_safe
  end

  def twitter_tweet_button pager_url, text
    '<a href="https://twitter.com/share" class="twitter-share-button" data-url="'+pager_url+'" data-text="' + text + '">Tweet</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>'.html_safe
  end

  def image_tag_unknown_extension(unknown_extension_url)
    extension_code = lambda { |extension|
      url = URI.parse(unknown_extension_url + extension)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
      res.code
    }
    jpeg_code = extension_code.call '.jpg'
    if jpeg_code == '404'
      gif_code = extension_code.call '.gif'
      if gif_code == '404'
        png_code = extension_code.call '.png'
        png_code == '404' ? (image_tag 'pixel.gif') : (image_tag unknown_extension_url + '.png')
      else
        image_tag unknown_extension_url + '.gif'
      end
    else
      image_tag unknown_extension_url + '.jpg'
    end
  end

  def get_home_path
    session[:extension_origin].nil? ? google_search_path : session[:extension_origin]
  end

  def check_withdrawal_errors(params)
    params.present? && params == "true"
  end

  def advertiser_coupons(advertiser)
    advertiser.coupons.where(['expires_at IS NULL or expires_at >= ?', Date.today])
  end
end
