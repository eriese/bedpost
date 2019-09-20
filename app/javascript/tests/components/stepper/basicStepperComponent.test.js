import {shallowMount} from "@vue/test-utils";
import BasicStepper from "@components/stepper/BasicStepperComponent";

describe("Basic Stepper Component", () => {
	test('It has a render function', () => {
		let stepper = shallowMount(BasicStepper, {
			propsData: {
				defaultProps: {
					animLength: 0.2
				}
			},
			scopedSlots: {
				default: '<div slot-scope="{step, setStep}">{{step}}</div>'
			}
		});

		expect(stepper.text()).toContain("0");
	})
})
