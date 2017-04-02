# Pivotal Tracker - Gitlab Code Review

**Code Review integration helper for Gitlab**

Set specified label (default `on_code_review` ) to Pivotal Tracker when merge request is opened, and remove tag when request is marged or closed.

Can be useful, as Pivotal Tracker stories cannot have any custom statuses between "started" and "finished", to mark that story are finished, but not merged in main branch yet.

## Installation

1. Install elixir lang

2. Prepare config:

  ```
  cp config/config.exs.example config/config.exs
  vim config/config.exs
  ```

3. Run app:

  ```
  mix run --no-halt
  ```

## Connecting to GitLab

Add webhook URL on Integrations page in the GitLab project settings:

    http://example.com:4000/merge_request/12345678

where `example.com:4000` is your deployed service address, and `12345678` is a Pivotal Tracker project ID which you want to integrate with.
