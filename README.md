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
