<script>
import { gsap } from 'gsap';

export default {
	data: function() {
		return {
			isOpen: false,
			closing: false
		};
	},
	props: {
		titleButton: {
			type: Boolean,
			default: false
		},
		startOpen: Boolean,
		selector: {
			type: String,
			default: 'div'
		}
	},
	methods: {
		toggle(isTitle) {
			if (isTitle && !this.titleButton) {
				return;
			}

			if (this.isOpen) {
				this.closing = true;
				gsap.to(this.$refs.content, 0.3, {height: '0px', overflow: 'hidden', clearProps: 'height,overflow', onComplete: ()=> {
					this.isOpen = false;
					this.closing = false;
				}});
			} else {
				this.isOpen = true;
				gsap.from(this.$refs.content, 0.3, {height: '0px', overflow: 'hidden', clearProps: 'height,overflow'});
			}
		}
	},
	mounted() {
		if (this.startOpen) {
			this.isOpen = true;
		}
	},
	render(createElement) {
		let vm = this;

		const buttonDefault = (scope) => createElement('arrow-button',{
			class: vm.$attrs['arrow-class'],
			props: {
				direction: scope.isOpen ? 'up' : 'down'
			}
		});

		return createElement(vm.selector, {
			class: {
				'title-as-button': vm.titleButton,
				'dropdown--is-open': vm.isOpen,
				'dropdown--is-closed': vm.closing || !vm.isOpen,
				'dropdown': true
			},
		}, [
			createElement('span', {
				on: {
					click: () => {
						vm.toggle(true);
					}
				},
				class: ['dropdown-title'],
				slot: 'title'
			}, vm.$slots.title),
			createElement('span', {
				class: ['dropdown-button'],
				on: {
					click: () => {
						vm.toggle(false);
					}
				},
			}, [
				(vm.$scopedSlots.button || buttonDefault)({isOpen: vm.isOpen})
			]),
			createElement('div', {
				style: {
					display: vm.isOpen ? '' : 'none',
				},
				ref: 'content',
				class: ['dropdown-content'],
			}, [vm.$slots.default])
		]);
	}
};
</script>
