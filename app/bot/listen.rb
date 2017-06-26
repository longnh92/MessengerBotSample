require "facebook/messenger"
include Facebook::Messenger
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

def prompt_user_to_choose_operation(message)
  message.reply(
      text: 'Hi, Please choose an operation (Add, Multiply)',
      quick_replies: [
        {
          content_type: 'text',
          title: 'Add',
          payload: 'add'
        },
        {
          content_type: 'text',
          title: 'Multiply',
          payload: 'multiply'
        }
      ]
    )
end

def extract_operands_from(message)
  message.text.split('-').map(&:strip).map(&:to_i)
end

def wait_for_input_operands(message, &block)
  message.reply(text: 'Please input two operands with delimeter is \'-\'')
  Bot.on :message do |message|
    puts 'User input operands'
    ap message
    a,b = extract_operands_from(message)
    if a.present? && b.present?
      result = block.call(a,b)
      message.reply(text: result)
      wait_for_choosing_operation(message)
    else
      message.reply(text: 'Invalid operands.')
      wait_for_input_operands(message)
    end
  end
end

def wait_for_choosing_operation(message)
  prompt_user_to_choose_operation(message)
  Bot.on :message do |message|
    puts 'User choose an operation'
    ap message
    if message.text.downcase == 'add'
      do_add(message)
    elsif message.text.downcase == 'multiply'
      do_multiply(message)
    else
      message.reply(text: 'Invalid operation.')
      wait_for_choosing_operation(message)
    end
  end
end

def do_add(message)
  wait_for_input_operands(message) do |a, b|
    a + b
  end
end

def do_multiply(message)
  wait_for_input_operands(message) do |a, b|
    a * b
  end
end

def config
  Facebook::Messenger::Profile.set({
    persistent_menu: [
      {
        locale: 'default',
        composer_input_disabled: true,
        call_to_actions: [
          {
            title: 'My Account',
            type: 'nested',
            call_to_actions: [
              {
                title: 'Reset',
                type: 'postback',
                payload: 'GET_STARTED_PAYLOAD'
              }
            ]
          }
        ]
      }
    ],
    greeting: [
      {
        locale: 'default',
        text: 'Hi'
      }
    ],
    get_started: {
      payload: 'GET_STARTED_PAYLOAD'
    }
  }, access_token: ENV['ACCESS_TOKEN'])
end

def start_conversation
  Bot.on :postback do |message|
    puts 'start_conversation'
    ap message
    wait_for_choosing_operation(message)
  end
end

config
start_conversation

