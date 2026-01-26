package backend.types;

/**
 * Collection of splash texts, divided into shared, unique, and fallback categories.
 */
typedef SplashCollectionData = {
	/**
	 * Splashes that appear at all times.
	 */
	shared:Array<String>,
	/**
	 * Splashes that appear only during specific periods.
	 */
	unique:Array<SplashGroupData>,
	/**
	 * Splashes that appear if no unique splashes are active.
	 */
	fallback:Array<String>
}
