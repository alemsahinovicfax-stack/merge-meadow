extends RefCounted

## Tanki adapter na Poing AdMob plugin (v5.1.0): UMP pristanak → MobileAds → jedna rewarded +
## jedna interstitial reklama u memoriji. AdManager ga učitava samo na Androidu s pluginom
## (load() po putanji), pa desktop i smoke testovi nikad ne diraju plugin klase.
## Isti API ima lažni backend u test_ad_manager.gd.

var _rewarded: RewardedAd = null
var _interstitial: InterstitialAd = null
var _rewarded_loading: bool = false
var _interstitial_loading: bool = false
## Callable referenca drži loadere žive dok plugin ne javi rezultat.
var _loaders: Array = []


## on_done(can_request_ads: bool). debug_eea = test forma kao da je igrač u EU (samo debug build).
func start(debug_eea: bool, on_done: Callable) -> void:
	var params := ConsentRequestParameters.new()
	params.tag_for_under_age_of_consent = false
	if debug_eea:
		var debug := ConsentDebugSettings.new()
		debug.debug_geography = DebugGeography.Values.EEA
		params.consent_debug_settings = debug
	UserMessagingPlatform.consent_information.update(
		params,
		func() -> void: _on_consent_info_updated(on_done),
		func(error: FormError) -> void:
			# Bez mreže: Google dozvoljava reklame ako je pristanak ranije već dat (keš UMP-a).
			push_warning("AdMob UMP update failed: %s" % (error.message if error else "unknown"))
			_initialize_ads(on_done)
	)


func _on_consent_info_updated(on_done: Callable) -> void:
	var info := UserMessagingPlatform.consent_information
	if info.get_is_consent_form_available() and info.get_consent_status() == ConsentInformation.ConsentStatus.REQUIRED:
		UserMessagingPlatform.load_consent_form(
			func(form: ConsentForm) -> void:
				form.show(func(_error: FormError) -> void: _initialize_ads(on_done)),
			func(error: FormError) -> void:
				push_warning("AdMob consent form failed: %s" % (error.message if error else "unknown"))
				_initialize_ads(on_done)
		)
		return
	_initialize_ads(on_done)


func can_request_ads() -> bool:
	var status := UserMessagingPlatform.consent_information.get_consent_status()
	return status == ConsentInformation.ConsentStatus.NOT_REQUIRED \
		or status == ConsentInformation.ConsentStatus.OBTAINED


func _initialize_ads(on_done: Callable) -> void:
	if not can_request_ads():
		on_done.call(false)
		return
	var config := RequestConfiguration.new()
	# Ciljna publika 13+, ali crtani stil privlači i mlađe — samo reklame za sve uzraste (G),
	# kako preporučuje privacy-policy-draft.md.
	config.max_ad_content_rating = RequestConfiguration.MAX_AD_CONTENT_RATING_G
	config.tag_for_under_age_of_consent = RequestConfiguration.TagForUnderAgeOfConsent.FALSE
	MobileAds.set_request_configuration(config)
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(_status: InitializationStatus) -> void:
		on_done.call(true)
	MobileAds.initialize(listener)


func privacy_options_required() -> bool:
	return UserMessagingPlatform.consent_information.get_privacy_options_requirement_status() \
		== ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED


func show_privacy_options(on_closed: Callable) -> void:
	UserMessagingPlatform.show_privacy_options_form(func(_error: FormError) -> void: on_closed.call())


func reset_consent() -> void:
	UserMessagingPlatform.consent_information.reset()


# --- Rewarded ---

func has_rewarded() -> bool:
	return _rewarded != null


func load_rewarded(unit_id: String, on_done: Callable) -> void:
	if _rewarded != null:
		on_done.call(true)
		return
	if _rewarded_loading:
		return
	_rewarded_loading = true
	var loader := RewardedAdLoader.new()
	_loaders.append(loader)
	var cb := RewardedAdLoadCallback.new()
	cb.on_ad_loaded = func(ad: RewardedAd) -> void:
		_rewarded_loading = false
		_loaders.erase(loader)
		_rewarded = ad
		on_done.call(true)
	cb.on_ad_failed_to_load = func(error: LoadAdError) -> void:
		_rewarded_loading = false
		_loaders.erase(loader)
		push_warning("AdMob rewarded load failed: %s" % (error.message if error else "unknown"))
		on_done.call(false)
	loader.load(unit_id, AdRequest.new(), cb)


## on_earned() kad igrač odgleda; on_closed() kad se reklama zatvori; on_failed() ako se ne prikaže.
func show_rewarded(on_earned: Callable, on_closed: Callable, on_failed: Callable) -> void:
	var ad := _rewarded
	_rewarded = null
	if ad == null:
		on_failed.call()
		return
	ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		ad.destroy()
		on_closed.call()
	ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(_error: AdError) -> void:
		ad.destroy()
		on_failed.call()
	var reward := OnUserEarnedRewardListener.new()
	reward.on_user_earned_reward = func(_item: RewardedItem) -> void: on_earned.call()
	ad.show(reward)


# --- Interstitial ---

func has_interstitial() -> bool:
	return _interstitial != null


func load_interstitial(unit_id: String, on_done: Callable) -> void:
	if _interstitial != null:
		on_done.call(true)
		return
	if _interstitial_loading:
		return
	_interstitial_loading = true
	var loader := InterstitialAdLoader.new()
	_loaders.append(loader)
	var cb := InterstitialAdLoadCallback.new()
	cb.on_ad_loaded = func(ad: InterstitialAd) -> void:
		_interstitial_loading = false
		_loaders.erase(loader)
		_interstitial = ad
		on_done.call(true)
	cb.on_ad_failed_to_load = func(error: LoadAdError) -> void:
		_interstitial_loading = false
		_loaders.erase(loader)
		push_warning("AdMob interstitial load failed: %s" % (error.message if error else "unknown"))
		on_done.call(false)
	loader.load(unit_id, AdRequest.new(), cb)


## on_closed() i kad se zatvori i kad se ne uspije prikazati — Retry ide dalje u oba slučaja.
func show_interstitial(on_closed: Callable) -> void:
	var ad := _interstitial
	_interstitial = null
	if ad == null:
		on_closed.call()
		return
	ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		ad.destroy()
		on_closed.call()
	ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(_error: AdError) -> void:
		ad.destroy()
		on_closed.call()
	ad.show()
