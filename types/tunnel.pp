# A custom data type for a jenkins tunnel verification
type Jenkins::Tunnel = Variant[Pattern[/.+:$/],Pattern[/.+:[0-9]+/], Pattern[/^:[0-9]+/]]
