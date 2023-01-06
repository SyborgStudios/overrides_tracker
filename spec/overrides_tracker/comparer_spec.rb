require 'spec_helper'

describe OverridesTracker::Comparer do
  let(:obj) { OverridesTracker::Comparer }
  let(:file_one_hash) { {} }
  let(:file_two_hash) { {} }

  before do
    allow(Dir).to receive(:entries).and_return(['.', '..', 'file_one.otf', 'file_two.otf'])
    allow(OverridesTracker::MethodsCollector.instance).to receive(:load_from_file).with('file_one.otf').once.and_return(file_one_hash)
    allow(OverridesTracker::MethodsCollector.instance).to receive(:load_from_file).with('file_two.otf').once.and_return(file_two_hash)
  end

  describe '#compare' do
    context 'on instance_methods' do
      context 'when nothing diverges' do
        let(:file_one_hash) do
          {
            'methods_collection': {
              "ClassADifferentSources": {
                "instance_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                    "location": [
                      '/gem/models/class_a.rb',
                      7
                    ],
                    "body": "def method_one\n  master_original_implementation\nend\n",
                    "overriding_location": [
                      '/app/models/class_a.rb',
                      7
                    ],
                    "overriding_body": "def method_one\n  master_override\nend\n"
                  }
                }
              }
            },
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s
          }
        end

        let(:file_two_hash) do
          {
            'methods_collection': { "ClassADifferentSources": {
              "instance_methods": {
                "method_one": {
                  "sha": 'aaa',
                  "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                  "location": [
                      '/gem/models/class_a.rb',
                      7
                    ],
                  "body": "def method_one\n  master_original_implementation\nend\n",
                  "overriding_location": [
                      '/app/models/class_a.rb',
                      7
                    ],
                  "overriding_body": "def method_one\n  master_override\nend\n"
                }
              }
            } },
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s
          }
        end

        it 'should find 0 changes' do
          result = obj.compare
          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                        method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 0
                                         })
        end
      end

      context 'when original source diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "instance_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "instance_methods": {
                  "method_one": {
                    "sha": 'bbb',
                    "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 source changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 2, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when overrides diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "instance_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '111',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "instance_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '222',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 override changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 2, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when one becomes a added_method' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "instance_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_instance_methods": {
                  "method_one": {
                    "sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                    "location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  master_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 0 changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 1, method_not_available_count: 0,
                                                          method_not_override_count: 1, total: 2 }, added_methods: { source_changed_count: 1, override_changed_count: 0, method_not_available_count: 1, method_not_override_count: 0, total: 2 }, total: 4
                                         })
        end
      end

      context 'when a whole override class is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': { "ClassADifferentSources": {
           "instance_methods": {
             "method_one": {
               "sha": 'aaa',
               "overriding_sha": '111',
               "location": [
                   '/gem/models/class_a.rb',
                   7
                 ],
               "body": "def method_one\n  master_original_implementation\nend\n",
               "overriding_location": [
                   '/app/models/class_a.rb',
                   7
                 ],
               "overriding_body": "def method_one\n  master_override\nend\n"
             }
           }
         } }
          }
        end

        let(:file_two_hash) do
          { 'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': {} }
        end

        it 'should find 1 override_change and 1 method_not_available' do
          result = obj.compare
          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 1, method_not_available_count: 1,
                                                        method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when a override method is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "instance_methods": {}
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "instance_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '222',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 1 override_change and 1 method_not_available' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 1, method_not_available_count: 1,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end
    end

    context 'on singleton_methods' do
      context 'when nothing diverges' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "singleton_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "singleton_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  master_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  master_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 0 changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 0
                                         })
        end
      end

      context 'when original source diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "singleton_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "singleton_methods": {
                  "method_one": {
                    "sha": 'bbb',
                    "overriding_sha": '376988d98a7069f2a2914a4544d4e2d1d519f345',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 source changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 2, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when overrides diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "singleton_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "overriding_sha": '111',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n",
                         "overriding_location": [
                             '/app/models/class_a.rb',
                             7
                           ],
                         "overriding_body": "def method_one\n  master_override\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "singleton_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '222',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 override changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 2, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when a whole override class is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': { "ClassADifferentSources": {
           "singleton_methods": {
             "method_one": {
               "sha": 'aaa',
               "overriding_sha": '111',
               "location": [
                   '/gem/models/class_a.rb',
                   7
                 ],
               "body": "def method_one\n  master_original_implementation\nend\n",
               "overriding_location": [
                   '/app/models/class_a.rb',
                   7
                 ],
               "overriding_body": "def method_one\n  master_override\nend\n"
             }
           }
         } }
          }
        end

        let(:file_two_hash) do
          { 'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': {} }
        end

        it 'should find 1 override_change and 1 method_not_available' do
          result = obj.compare
          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 1, method_not_available_count: 1,
                                                        method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end

      context 'when a override method is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "singleton_methods": {}
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "singleton_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "overriding_sha": '222',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n",
                    "overriding_location": [
                        '/app/models/class_a.rb',
                        7
                      ],
                    "overriding_body": "def method_one\n  other_override\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 1 override_change and 1 method_not_available' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 1, method_not_available_count: 1,
                                                          method_not_override_count: 0, total: 2 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 2
                                         })
        end
      end
    end

    context 'on added_instance_methods' do
      context 'when nothing diverges' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_instance_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_instance_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  master_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 0 changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 0
                                         })
        end
      end

      context 'when original source diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_instance_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_instance_methods": {
                  "method_one": {
                    "sha": 'bbb',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 source changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 2, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end

      context 'when a whole added class is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': { "ClassADifferentSources": {
           "added_instance_methods": {
             "method_one": {
               "sha": 'aaa',
               "location": [
                   '/gem/models/class_a.rb',
                   7
                 ],
               "body": "def method_one\n  master_original_implementation\nend\n"
             }
           }
         } }
          }
        end

        let(:file_two_hash) do
          { 'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': {} }
        end

        it 'should find 1 source_change and 1 method_not_available' do
          result = obj.compare
          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                        method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 1, override_changed_count: 0, method_not_available_count: 1, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end

      context 'when a override method is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_instance_methods": {}
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_instance_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 1 souce_change and 1 method_not_available' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 1, override_changed_count: 0, method_not_available_count: 1, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end
    end

    context 'on added_singleton_methods' do
      context 'when nothing diverges' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_singleton_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_singleton_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  master_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 0 changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 0 }, total: 0
                                         })
        end
      end

      context 'when original source diverge' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_singleton_methods": {
                      "method_one": {
                        "sha": 'aaa',
                         "location": [
                             '/gem/models/class_a.rb',
                             7
                           ],
                         "body": "def method_one\n  master_original_implementation\nend\n"
                      }
                    }
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_singleton_methods": {
                  "method_one": {
                    "sha": 'bbb',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 2 source changes' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 2, override_changed_count: 0, method_not_available_count: 0, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end

      context 'when a whole added class is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': { "ClassADifferentSources": {
           "added_singleton_methods": {
             "method_one": {
               "sha": 'aaa',
               "location": [
                   '/gem/models/class_a.rb',
                   7
                 ],
               "body": "def method_one\n  master_original_implementation\nend\n"
             }
           }
         } }
          }
        end

        let(:file_two_hash) do
          { 'working_directory': Dir.pwd,
            'bundle_path': Bundler.bundle_path.to_s,
            'methods_collection': {} }
        end

        it 'should find 1 source_change and 1 method_not_available' do
          result = obj.compare
          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                        method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 1, override_changed_count: 0, method_not_available_count: 1, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end

      context 'when a override method is missing' do
        let(:file_one_hash) do
          {
            'working_directory': Dir.pwd,
                       'bundle_path': Bundler.bundle_path.to_s,
                       'methods_collection': { "ClassADifferentSources": {
                    "added_singleton_methods": {}
                  } }
          }
        end

        let(:file_two_hash) do
            {
              'working_directory': Dir.pwd,
                'bundle_path': Bundler.bundle_path.to_s,
                'methods_collection': { "ClassADifferentSources": {
                "added_singleton_methods": {
                  "method_one": {
                    "sha": 'aaa',
                    "location": [
                        '/gem/models/class_a.rb',
                        7
                      ],
                    "body": "def method_one\n  other_original_implementation\nend\n"
                  }
                }
              } }
            }
        end

        it 'should find 1 souce_change and 1 method_not_available' do
          result = obj.compare

          expect(result[:numbers]).to eq({
                                           overrides: { source_changed_count: 0, override_changed_count: 0, method_not_available_count: 0,
                                                          method_not_override_count: 0, total: 0 }, added_methods: { source_changed_count: 1, override_changed_count: 0, method_not_available_count: 1, method_not_override_count: 0, total: 2 }, total: 2
                                         })
        end
      end
    end
  end
end
