import re

with open('test/features/health_sharing/infrastructure/wifi_direct_service_test.dart', 'r') as f:
    content = f.read()

# Make discovery return a mock map so BonsoirDiscovery sees it
# Actually the mock handler just intercepts 'discovery.start'.
# Bonsoir uses an EventChannel 'fr.skyost.bonsoir.discovery' for events.
# We should probably just use fakeAsync to skip the delay and replace the mock to something simpler?
# Wait! Bonsoir uses platform channels. If it doesn't get events, devices are empty.
# We can mock discovery to just skip if we inject an event. Or better, just override BonsoirDiscovery if we could.
