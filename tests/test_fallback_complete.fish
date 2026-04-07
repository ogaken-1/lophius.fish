# Test that __lophius_fallback_complete is defined after sourcing

source (status dirname)/../functions/__lophius_fallback_complete.fish

@test "__lophius_fallback_complete is defined" (functions -q __lophius_fallback_complete) $status -eq 0
