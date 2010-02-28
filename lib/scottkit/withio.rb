# Provides a utility method withIO() used by several test-cases.  Runs
# the specified block with stdin and stdout replumbed to the provided
# file-handles; the old values of stdin and stdout are passed to the
# block, in case they should be needed.

def withIO(newin, newout)
  old_STDIN = $stdin
  old_STDOUT = $stdout
  $stdin = newin
  $stdout = newout
  yield old_STDIN, old_STDOUT
ensure
  $stdin = old_STDIN
  $stdout = old_STDOUT
end
