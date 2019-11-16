import {mount} from "@vue/test-utils"
import Bubble from "@components/display/Bubble.vue"

const mockPosition = jest.fn();

describe("Bubble component", () => {
	test("It renders the slot content", () => {
		const txt = "some text"
		const wrapper = mount(Bubble, {
			slots: {
				default: txt
			},
			methods: {
				setPosition: mockPosition
			}
		})

		expect(wrapper.text()).toBe(txt)
	})

	describe("on mount", () => {
		test("It looks for its target", () => {
			const mockGetTarget = jest.fn();

			const wrapper = mount(Bubble, {
				slots: {
					default: "some text"
				},
				methods: {
					getTargetEl: mockGetTarget
				}
			})

			expect(mockGetTarget).toHaveBeenCalledTimes(1);
		})

		test("If there is a target, it positions itself", () => {
			mockPosition.mockClear();
			const mockDebounce = jest.fn();
			document.getElementById = () => "here"

			const wrapper = mount(Bubble, {
				slots: {
					default: "some text"
				},
				methods: {
					setPosition: mockPosition,
					debounceTargetEl: mockDebounce
				}
			})

			expect(mockPosition).toHaveBeenCalledTimes(1);
			expect(mockDebounce).not.toHaveBeenCalled();
		})

		test("If there is no target, it queues another check", () => {
			mockPosition.mockClear()
			const mockDebounce = jest.fn();
			document.getElementById = () => undefined

			const wrapper = mount(Bubble, {
				slots: {
					default: "some text"
				},
				methods: {
					debounceTargetEl: mockDebounce,
					setPosition: mockPosition
				}
			})

			expect(mockDebounce).toHaveBeenCalledTimes(1);
			expect(mockPosition).not.toHaveBeenCalled();
		})

		test("It adds a resize event listener", () => {
			const mockAdd = jest.fn();
			window.addEventListener = mockAdd

			const wrapper = mount(Bubble, {
				slots: {
					default: "some text"
				},
				methods: {
					getTargetEl: jest.fn(),
				}
			})

			expect(mockAdd).toHaveBeenCalledWith('resize', wrapper.vm.debounceTargetEl);
		})
	})

	test("on destroy it removes the resize listener", () => {
		const listener = "listener"
		window.addEventListener = () => listener

		const mockRemove = jest.fn();
		window.removeEventListener = mockRemove
		const wrapper = mount(Bubble, {
			slots: {
				default: "some text"
			},
			methods: {
				getTargetEl: jest.fn(),
			}
		})
		wrapper.destroy();

		expect(mockRemove).toHaveBeenCalledWith('resize', listener);
	})

	describe("setPosition method", () => {
		let targetRect;
		let elRect;
		let count = 0;
		global.Utils = {
			getBoundingDocumentRect: function() {return [targetRect, elRect][count++]}
		}

		const wrapper = mount(Bubble, {
			slots: {
				default: "some text"
			},
			propsData: {
				position: 'centerX'
			},
			mounted() {}
		})

		wrapper.setData({"targetEl": true});
		let bubbleWidth = 10;
		const bubble = wrapper.find({ref: "bubble"}).element;

		const setBubbleWidth = (width) => {
			bubbleWidth = width;
			Object.defineProperty(bubble, 'offsetWidth', { configurable: true, value: bubbleWidth });
		}

		const expectPosition = (expectedLeft, expectedClass) => {
			wrapper.vm.setPosition();

			expect(wrapper.vm.cls).toEqual(expectedClass)
			expect(wrapper.vm.stl.left).toEqual(`${expectedLeft}px`)
		}

		beforeEach(() => {
			count = 0;
		})

		describe("with position 'centerX' it aligns the pointer with the center x of the target element", () =>{

			beforeAll(() => {
				wrapper.setProps({position: 'centerX'})
			})

			test("left-justify", () => {
				targetRect = {centerX: 40, right: 70}
				elRect = {left: 10, width: 70}
				setBubbleWidth(20);

				const expected = targetRect.centerX - elRect.left
				expectPosition(expected, "left-justify")
			})

			test("center-justify", () => {
				targetRect = {centerX: 40, right: 70}
				elRect = {left: 10, width: 70}
				setBubbleWidth(50)

				const expected = targetRect.centerX - elRect.left - bubbleWidth / 2
				expectPosition(expected, "center-justify")
			})

			test("right-justify", () => {
				targetRect = {centerX: 40, right: 45}
				elRect = {left: 10, width: 45}
				setBubbleWidth(20)

				const expected = targetRect.centerX - elRect.left - bubbleWidth
				expectPosition(expected, "right-justify")
			})
		})

		describe("with position 'right' it aligns the pointer with the right edge of the target element", () => {
			beforeAll(() => {
				wrapper.setProps({position: 'right'})
			})

			test("left-justify", () => {
				targetRect = {centerX: 40, right: 70}
				elRect = {left: 10, width: 80}
				setBubbleWidth(15);

				const expected = targetRect.right - elRect.left
				expectPosition(expected, "left-justify")
			})

			test("center-justify", () => {
				targetRect = {centerX: 40, right: 50}
				elRect = {left: 10, width: 70}
				setBubbleWidth(50)

				const expected = targetRect.right - elRect.left - bubbleWidth / 2
				expectPosition(expected, "center-justify")
			})

			test("right-justify", () => {
				targetRect = {centerX: 40, right: 45}
				elRect = {left: 10, width: 45}
				setBubbleWidth(20)

				const expected = targetRect.right - elRect.left - bubbleWidth
				expectPosition(expected, "right-justify")
			})
		})
	})
})
