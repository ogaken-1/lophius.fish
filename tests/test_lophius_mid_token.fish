# Test that lophius falls back to native completion when cursor is mid-token

source (status dirname)/../functions/lophius.fish

# Helper: override commandline to simulate mid-token state
# Records the argument passed to 'commandline -f' to verify which completion is triggered
function _test_mid_token_fallback
  set -g _lophius_test_commandline_f_arg ""

  function commandline
    switch $argv[1]
      case --paging-mode
        return 1  # paging mode is off
      case -t
        echo "fea"  # non-empty token = mid-token
      case -f
        set -g _lophius_test_commandline_f_arg $argv[2]
    end
  end

  lophius

  functions --erase commandline
  echo $_lophius_test_commandline_f_arg
  set -e _lophius_test_commandline_f_arg
end

@test "lophius calls 'commandline -f complete' (not repaint) when mid-token" (_test_mid_token_fallback) = complete
