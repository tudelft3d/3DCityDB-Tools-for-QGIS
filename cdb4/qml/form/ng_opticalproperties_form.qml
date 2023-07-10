<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="glazingratio">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="glazingratio_uom">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" index="0" name="Database ID"/>
    <alias field="glazingratio" index="1" name="Glazing Ratio"/>
    <alias field="glazingratio_uom" index="2" name="Glazing Ratio UoM"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="id" unique_strength="1" constraints="3" exp_strength="0"/>
    <constraint notnull_strength="0" field="glazingratio" unique_strength="0" constraints="4" exp_strength="1"/>
    <constraint notnull_strength="0" field="glazingratio_uom" unique_strength="0" constraints="4" exp_strength="1"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="(&quot;glazingratio&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;glazingratio_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;glazingratio&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;glazingratio_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="glazingratio"/>
    <constraint exp="(&quot;glazingratio&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;glazingratio_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;glazingratio&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;glazingratio_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="glazingratio_uom"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorField showLabel="1" name="id" index="0"/>
    <attributeEditorField showLabel="1" name="glazingratio" index="1"/>
    <attributeEditorField showLabel="1" name="glazingratio_uom" index="2"/>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Reflectance" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Reflectance" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Transmittance" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Transmittance" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
