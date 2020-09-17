class TelegramWebhooksController < Telegram::Bot::UpdatesController
  use_session!
  self.session_store = :file_store # override global session store
  include Telegram::Bot::UpdatesController::MessageContext

  # init conversation
  def start!(data = nil, *)
    response = from ? "Hello #{from['username']}!" : 'Hi there!'
    respond_with :message, text: response
  end

  # store and read from session
  def write!(text = nil, *)
    session[:text] = text
  end

  def read!(*)
    respond_with :message, text: session[:text]
  end

  # keyboard in chat
  def inline_keyboard!(*)
    respond_with :message, text: 'Chose Buttons', reply_markup: {
      inline_keyboard: [
        [
          { text: 'text-2', callback_data: 'call-back-2' },
          { text: 'text-3', callback_data: 'call-back-3' }
        ],
        [{ text: 'text-4', url: 'https://github.com/telegram-bot-rb/telegram-bot' }]
      ]
    }
  end

  # this react on /inline_keyboard
  def callback_query(data)
    case data
    when 'call-back-1'
      answer_callback_query 'clicked 1', show_alert: true
    when 'call-back-2'
      answer_callback_query 'clicked 2'
    else
      answer_callback_query 'bla'
    end
  end

  def keyboard!(value = nil, *)
    p '========='
    p value
    p '========='
    if value
      respond_with :message, text: 'text1', value: value
    else
      save_context :keyboard!
      respond_with :message, text: 'text2', reply_markup: {
        keyboard: [
          [
            { text: 'text-2', callback_data: 'call-back-2' },
              { text: 'text-3', callback_data: 'call-back-3' }
          ],
            [{ text: 'text-4', url: 'https://github.com/telegram-bot-rb/telegram-bot' }]
        ],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def inline_query(query, _offset)
    byebug
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = Array.new(5) do |i|
      {
          type: :article,
          title: "#{query}-#{i}",
          id: "#{query}-#{i}",
          description: "#{t_description} #{i}",
          input_message_content: {
              message_text: "#{t_content} #{i}",
          },
      }
    end
    answer_inline_query results
  end

  def message(message)
    respond_with :message, text: message
  end

  private

  def with_locale(&block)
    I18n.with_locale(locale_for_update, &block)
  end

  def locale_for_update
    if from
      # locale for user
    elsif chat
      # locale for chat
    end
  end

  def message_id
    update['message']['from']['id']
  end
end
