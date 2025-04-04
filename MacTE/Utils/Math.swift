//Created by Lugalu on 23/02/25.

import Foundation

func clamp<T: Numeric & Comparable >(_ minValue: T, _ value: T, _ maxValue: T ) -> T {
	return min( maxValue,
				max(minValue,
					value)
	)
}
